local gui = require("__flib__.gui")

local actions = require("scripts.gui.task.actions")
local constants = require("constants")
local templates = require("scripts.gui.templates")

--- @class TaskGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement

--- @class TaskGui
local TaskGui = {}

TaskGui.actions = actions

function TaskGui:destroy()
  local window = self.refs.window
  if window and window.valid then
    self.refs.window.destroy()
  end

  self.player_table.guis.task[self.Task.id] = nil
end

function TaskGui:open()
  self.refs.window.bring_to_front()
  self.refs.window.visible = true
end

function TaskGui:close()
  self.refs.window.visible = false

  if self.player.opened == self.refs.window then
    self.player.opened = nil
  end
end

function TaskGui:toggle()
  if self.refs.window.visible then
    self:close()
  else
    self:open()
  end
end

function TaskGui:dispatch(msg, e)
  if msg.action then
    local handler = self.actions[msg.action]
    if handler then
      handler(self, msg, e)
    end
  end
end

-- BOOTSTRAP

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param Task Task
function index.new(player, player_table, Task)
  local status_items = {}
  local selected_status_index = 1
  for status_name, status_info in pairs(constants.task_status) do
    if status_name == Task.status then
      selected_status_index = status_info.index
    end
    table.insert(status_items, { "", "[img=flib_indicator_" .. status_info.color .. "]  ", status_info.label })
  end

  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      style_mods = { width = 500 },
      direction = "vertical",
      ref = { "window" },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar_flow" },
        actions = { on_click = { gui = "task", gui_id = Task.id, action = "recenter" } },
        { type = "label", style = "frame_title", caption = { "gui.tlst-task" }, ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
        templates.frame_action_button(
          "utility/close",
          { "gui.close" },
          { gui = "task", gui_id = Task.id, action = "close" }
        ),
      },
      {
        type = "frame",
        style = "inside_shallow_frame",
        direction = "vertical",
        {
          type = "frame",
          style = "subheader_frame",
          { type = "label", style = "subheader_caption_label", caption = Task.title },
          { type = "empty-widget", style = "flib_horizontal_pusher" },
          {
            type = "drop-down",
            items = status_items,
            selected_index = selected_status_index,
            ref = { "status_dropdown" },
          },
          {
            type = "sprite-button",
            style = "tool_button",
            sprite = "utility/rename_icon_normal",
            tooltip = { "gui.tlst-edit-task" },
          },
        },
        {
          type = "flow",
          style_mods = { padding = 12, vertical_spacing = 12 },
          direction = "vertical",
          {
            type = "frame",
            style = "tlst_description_frame",
            style_mods = { horizontally_stretchable = true },
            visible = #Task.description > 0,
            {
              type = "label",
              style_mods = { single_line = false },
              caption = Task.description,
            },
          },
          {
            type = "frame",
            style = "flib_shallow_frame_in_shallow_frame",
            direction = "vertical",
            {
              type = "frame",
              style = "subheader_frame",
              style_mods = { left_padding = 12 },
              { type = "checkbox", caption = { "gui.tlst-show-completed" }, state = false },
              { type = "empty-widget", style = "flib_horizontal_pusher" },
              {
                type = "sprite-button",
                style = "flib_tool_button_light_green",
                sprite = "utility/add",
                tooltip = { "gui.tlst-new-task" },
                actions = {
                  on_click = { gui = "task", gui_id = Task.id, action = "edit_task" },
                },
              },
            },
            { type = "scroll-pane", style = "flib_naked_scroll_pane" },
          },
        },
      },
    },
  })

  refs.titlebar_flow.drag_target = refs.window
  refs.window.force_auto_center()

  --- @type TaskGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    state = {},
    Task = Task,
  }

  index.load(self)

  player_table.guis.task[Task.id] = self
end

--- @param Gui TasksGui
function index.load(Gui)
  setmetatable(Gui, { __index = TaskGui })
end

return index
