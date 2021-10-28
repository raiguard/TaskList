local gui = require("__flib__.gui")

local actions = require("actions")
local templates = require("templates")

-- GUI

--- @class TasksGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field pin_button LuaGuiElement
--- @field title_textfield LuaGuiElement
--- @field description_textfield LuaGuiElement
--- @field scroll_pane LuaGuiElement

--- @class TasksGui
local TasksGui = {}

TasksGui.actions = actions

function TasksGui:destroy()
  local window = self.refs.window
  if window and window.valid() then
    self.refs.window.destroy()
  end
end

function TasksGui:open()
  self.refs.window.bring_to_front()
  self.refs.window.visible = true
  self.state.visible = true

  if not self.state.pinned then
    self.player.opened = self.refs.window
  end

  -- self.player.set_shortcut_toggled("tlst-toggle-gui", true)
end

function TasksGui:close()
  if self.state.pinning then
    return
  end

  self.refs.window.visible = false
  self.state.visible = false

  if self.player.opened == self.refs.window then
    self.player.opened = nil
  end

  -- self.player.set_shortcut_toggled("tlst-toggle-gui", false)
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

function TasksGui:delete_task(task_id)
  --- @type LuaGuiElement
  local row = self.refs.scroll_pane[tostring(task_id)]
  if row then
    row.destroy()
  end
end

function TasksGui:update_tasks()
  -- TEMPORARY: Destroy and recreate it all

  local scroll_pane = self.refs.scroll_pane
  scroll_pane.clear()

  -- TODO: We will have to preserve the ordering of tasks per-player
  for _, task in pairs(global.tasks) do
    gui.add(scroll_pane, {
      type = "flow",
      name = task.id,
      style_mods = { vertical_align = "center" },
      { type = "button", style = "mini_button_aligned_to_text_vertically_when_centered", caption = "v" },
      {
        type = "checkbox",
        caption = task.title,
        state = task.completed,
        actions = {
          on_checked_state_changed = { gui = "tasks", action = "toggle_task_completed", task_id = task.id },
        },
      },
      {
        type = "sprite-button",
        style = "tool_button_red",
        sprite = "utility/trash",
        actions = {
          on_click = { gui = "tasks", action = "delete_task", task_id = task.id },
        },
      },
    })
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
          { type = "textfield", ref = { "title_textfield" } },
          { type = "textfield", ref = { "description_textfield" } },
          {
            type = "button",
            style = "confirm_button",
            caption = "Create",
            actions = {
              on_click = { gui = "tasks", action = "create_task" },
            },
          },
        },
        {
          type = "scroll-pane",
          style = "flib_naked_scroll_pane",
          ref = { "scroll_pane" },
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
      pinned = false,
      pinning = false,
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
