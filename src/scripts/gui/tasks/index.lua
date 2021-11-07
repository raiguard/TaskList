local gui = require("__flib__.gui")

local actions = require("actions")
local templates = require("templates")

-- GUI

--- @class TasksGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field pin_button LuaGuiElement
--- @field scroll_pane LuaGuiElement
--- @field force_flow LuaGuiElement
--- @field private_flow LuaGuiElement

--- @class TasksGui
local TasksGui = {}

TasksGui.actions = actions

function TasksGui:destroy()
  local window = self.refs.window
  if window and window.valid then
    self.refs.window.destroy()
  end

  self.player_table.guis.tasks = nil
end

function TasksGui:open()
  self.refs.window.bring_to_front()
  self.refs.window.visible = true
  self.state.visible = true

  if not self.state.pinned then
    self.player.opened = self.refs.window
  end

  self.player.set_shortcut_toggled("tlst-toggle-gui", true)
end

function TasksGui:close()
  if self.state.ignore_close then
    self.state.ignore_close = false
    return
  end

  self.refs.window.visible = false
  self.state.visible = false

  if self.player.opened == self.refs.window then
    self.player.opened = nil
  end

  self.player.set_shortcut_toggled("tlst-toggle-gui", false)
end

function TasksGui:toggle()
  if self.state.visible then
    self:close()
  else
    self:open()
  end
end

function TasksGui:dispatch(msg, e)
  local transform = msg.transform
  if transform then
    if transform == "handle_titlebar_click" and e.button == defines.mouse_button_type.middle then
      msg.action = "recenter"
    end
  end

  if msg.action then
    local handler = self.actions[msg.action]
    if handler then
      handler(self, msg, e)
    end
  end
end

--- @param Task Task
--- @param index number
function TasksGui:add_task(Task, index)
  local flow = Task.owner.object_name == "LuaForce" and self.refs.force_flow or self.refs.private_flow
  gui.add(flow, {
    type = "flow",
    name = Task.id,
    direction = "vertical",
    index = index or nil,
    {
      type = "flow",
      style_mods = { vertical_align = "center" },
      {
        type = "checkbox",
        style_mods = { horizontally_stretchable = true, horizontally_squashable = true },
        caption = Task.title,
        state = Task.completed,
        actions = {
          on_checked_state_changed = { gui = "tasks", action = "toggle_task_completed", task_id = Task.id },
        },
      },
      {
        type = "label",
        style = "info_label",
        style_mods = { right_margin = 8 },
        caption = Task.assignee and Task.assignee.name or nil,
        visible = Task.assignee and true or false,
      },
      {
        type = "sprite-button",
        style = "mini_button_aligned_to_text_vertically_when_centered",
        sprite = "utility/rename_icon_small_black",
        tooltip = { "gui.tlst-edit-task" },
        actions = {
          on_click = { gui = "tasks", action = "edit_task", task_id = Task.id },
        },
      },
      {
        type = "sprite-button",
        style = "mini_button_aligned_to_text_vertically_when_centered",
        sprite = "tlst_arrow_right",
        tooltip = { "gui.tlst-toggle-details" },
        actions = {
          on_click = { gui = "tasks", action = "expand_task", task_id = Task.id },
        },
      },
    },
    {
      type = "flow",
      name = "details_flow",
      style_mods = { left_margin = 20 },
      direction = "vertical",
      visible = false,
      {
        type = "frame",
        style = "tlst_description_frame",
        style_mods = { horizontally_stretchable = true },
        visible = #Task.description > 0,
        {
          type = "label",
          style = "label_with_left_padding",
          style_mods = { single_line = false },
          caption = Task.description,
        },
      },
      {
        type = "flow",
        style_mods = { padding = 0, margin = 0, horizontal_spacing = 8 },
        {
          type = "sprite-button",
          style = "mini_button_aligned_to_text_vertically",
          sprite = "utility/add",
          tooltip = { "gui.tlst-add-subtask" },
        },
        { type = "label", caption = { "gui.tlst-add-subtask" } },
      },
    },
  })
end

--- @param Task Task
function TasksGui:update_task(Task)
  --- @type LuaGuiElement
  local flow = Task.owner.object_name == "LuaForce" and self.refs.force_flow or self.refs.private_flow
  local row = flow[tostring(Task.id)]
  if row then
    local assignee_name = Task.assignee and Task.assignee.name or nil
    gui.update(row, {
      {
        { elem_mods = { caption = Task.title } },
        { elem_mods = { caption = assignee_name, visible = assignee_name and true or false } },
      },
      {
        {
          elem_mods = { visible = #Task.description > 0 },
          { elem_mods = { caption = Task.description } },
        },
      },
    })
  end
end

--- @param Task Task
function TasksGui:delete_task(Task)
  --- @type LuaGuiElement
  local flow = Task.owner.object_name == "LuaForce" and self.refs.force_flow or self.refs.private_flow
  local row = flow[tostring(Task.id)]
  if row then
    row.destroy()
  end
end

-- BOOTSTRAP

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function index.new(player, player_table)
  --- @type TasksGuiRefs
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      style_mods = { width = 500 },
      direction = "vertical",
      ref = { "window" },
      visible = false,
      actions = {
        on_closed = { gui = "tasks", action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar_flow" },
        actions = {
          on_click = { gui = "tasks", transform = "handle_titlebar_click" },
        },
        { type = "label", style = "frame_title", caption = { "gui.tlst-tasks" }, ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
        templates.frame_action_button(
          "flib_pin",
          { "gui.flib-keep-open" },
          { gui = "tasks", action = "pin" },
          { "pin_button" }
        ),
        templates.frame_action_button("utility/close", { "gui.close-instruction" }, {
          gui = "tasks",
          action = "close",
        }),
      },
      {
        type = "frame",
        style = "inside_shallow_frame",
        direction = "vertical",
        {
          type = "frame",
          style = "subheader_frame",
          {
            type = "checkbox",
            style_mods = { left_margin = 8 },
            caption = { "gui.tlst-show-completed" },
            state = false,
            ref = { "show_completed_checkbox" },
          },
          { type = "empty-widget", style = "flib_horizontal_pusher" },
          {
            type = "switch",
            left_label_caption = { "gui.tlst-force" },
            right_label_caption = { "gui.tlst-private" },
            switch_state = "left",
            actions = {
              on_switch_state_changed = { gui = "tasks", action = "toggle_tasks_mode" },
            },
          },
          { type = "empty-widget", style_mods = { width = 20 } },
          {
            type = "sprite-button",
            style = "flib_tool_button_light_green",
            sprite = "utility/add",
            tooltip = { "gui.tlst-edit-task" },
            actions = {
              on_click = { gui = "tasks", action = "edit_task" },
            },
          },
        },
        {
          type = "scroll-pane",
          style = "flib_naked_scroll_pane",
          ref = { "scroll_pane" },
          { type = "flow", direction = "vertical", ref = { "force_flow" } },
          { type = "flow", direction = "vertical", ref = { "private_flow" }, visible = false },
        },
      },
    },
  })

  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window

  --- @type TasksGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    --- @class TasksGuiState
    state = {
      ignore_close = false,
      pinned = false,
      visible = false,
    },
  }

  setmetatable(self, { __index = TasksGui })

  player_table.guis.tasks = self
end

--- @param Gui TasksGui
function index.load(Gui)
  setmetatable(Gui, { __index = TasksGui })
end

return index
