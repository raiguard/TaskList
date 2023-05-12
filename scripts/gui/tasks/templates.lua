local constants = require("__TaskList__/constants")

local templates = {}

--- @param name string
--- @param visible boolean|nil
function templates.checkboxes_flow(name, visible)
  return {
    type = "flow",
    direction = "vertical",
    ref = { name .. "_flow" },
    { type = "flow", name = "incompleted", direction = "vertical", visible = false },
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

-- XXX: See https://forums.factorio.com/100896
local toplevel_width = 452
local nesting_offset = 22
--- @param Task Task
--- @return number
local function get_task_description_width(Task)
  local nesting_level = 0
  repeat
    Task = Task.owner --[[@as Task?]]
    nesting_level = nesting_level + 1
  until Task.object_name ~= "Task"

  return toplevel_width - (nesting_offset * nesting_level)
end

--- @param Task Task
--- @param index number|nil
--- @param completed boolean
function templates.task_item(Task, index, completed)
  return {
    type = "flow",
    name = Task.id,
    direction = "vertical",
    index = index or nil,
    {
      type = "flow",
      style = "tlst_task_item_flow",
      {
        type = "checkbox",
        style_mods = { horizontally_stretchable = true, horizontally_squashable = true },
        caption = Task.title,
        state = completed,
        actions = {
          on_checked_state_changed = { gui = "tasks", action = "toggle_task_completed", task_id = Task.id },
        },
      },
      {
        type = "label",
        style = "info_label",
        caption = Task.assignee and Task.assignee.name or nil,
        visible = Task.assignee and true or false,
      },
      {
        type = "sprite",
        style = "flib_indicator",
        sprite = "flib_indicator_" .. constants.task_status[Task.status].color,
        tooltip = constants.task_status[Task.status].label,
        actions = {
          on_click = { gui = "tasks", action = "cycle_task_status", task_id = Task.id },
        },
      },
      {
        type = "sprite-button",
        style = "mini_button_aligned_to_text_vertically_when_centered",
        sprite = "utility/rename_icon_small_black",
        tooltip = { "gui.tlst-edit-task" },
        actions = {
          on_click = {
            gui = "tasks",
            action = "edit_task",
            task_id = Task.id,
            parent_task_id = Task.owner.object_name == "Task" and Task.owner.id or nil,
          },
        },
      },
      {
        type = "sprite-button",
        style = "mini_button_aligned_to_text_vertically_when_centered",
        sprite = "tlst_arrow_right",
        tooltip = { "gui.tlst-expand-tooltip" },
        actions = {
          on_click = { gui = "tasks", transform = "handle_expand_click", task_id = Task.id },
        },
      },
    },
    {
      type = "flow",
      name = "details_flow",
      style_mods = { left_margin = 22 },
      direction = "vertical",
      visible = false,
      {
        type = "label",
        style_mods = {
          font_color = constants.description_color,
          single_line = false,
          width = get_task_description_width(Task),
        },
        caption = Task.description,
        visible = #Task.description > 0,
      },
      {
        type = "flow",
        name = "subtasks_flow",
        direction = "vertical",
        { type = "flow", name = "incompleted", direction = "vertical", visible = false },
        { type = "flow", name = "completed", direction = "vertical", visible = false },
        {
          type = "flow",
          style = "tlst_task_item_flow",
          {
            type = "label",
            style = "tlst_new_task_label",
            caption = { "gui.tlst-add-subtask" },
            actions = {
              on_click = { gui = "tasks", action = "edit_task", parent_task_id = Task.id },
            },
          },
          actions = {
            on_click = { gui = "tasks", action = "edit_task", parent_task_id = Task.id },
          },
        },
      },
    },
  }
end

return templates
