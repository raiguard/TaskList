local gui = require("__flib__.gui")

local actions = require("scripts.gui.task.actions")
local constants = require("constants")
local templates = require("scripts.gui.templates")
local util = require("scripts.util")

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
  if msg.transform and msg.transform == "handle_expand_click" then
    if e.button == defines.mouse_button_type.middle then
      msg.action = "open_task_gui"
    else
      if e.shift then
        msg.action = "move_task"
        msg.delta = -1
      elseif e.control then
        msg.action = "move_task"
        msg.delta = 1
      else
        msg.action = "expand_task"
      end
    end
  end

  if msg.action then
    local handler = self.actions[msg.action]
    if handler then
      handler(self, msg, e)
    end
  end
end

--- Get the parent flow for the given task
--- @param Task Task
function TaskGui:get_parent_flow(Task)
  local route = {}

  local owner = Task.owner
  while owner.object_name == "Task" and owner.id ~= self.Task.id do
    table.insert(route, 1, owner)
    owner = owner.owner
  end

  local flow = self.refs.subtasks_scroll_pane
  for _, owner in pairs(route) do
    local subflow = owner.completed and flow.completed or flow.incompleted
    local row = subflow[tostring(owner.id)]
    if row then
      flow = row.details_flow.subtasks_flow
    end
  end

  return flow
end

--- @param Task Task
--- @param index number
function TaskGui:add_task(Task, index, completed)
  if completed == nil then
    completed = Task.completed
  end
  local flow = self:get_parent_flow(Task)
  --- @type LuaGuiElement
  local flow = completed and flow.completed or flow.incompleted

  gui.add(flow, templates.task_item(Task, { name = "task", id = self.Task.id }, index, completed))

  if #flow.children > 0 and (not completed or self.state.show_completed) then
    flow.visible = true
  else
    flow.visible = false
  end

  -- Add subtasks
  for _, subtasks in pairs({ Task.completed_tasks, Task.tasks }) do
    for _, subtask_id in pairs(subtasks) do
      local subtask = global.tasks[subtask_id]
      if subtask then
        self:add_task(subtask)
      end
    end
  end
end

--- @param Task Task
function TaskGui:update_task(Task)
  local flow = self:get_parent_flow(Task)
  --- @type LuaGuiElement
  local flow = Task.completed and flow.completed or flow.incompleted

  local row = flow[tostring(Task.id)]
  if row then
    local status_info = constants.task_status[Task.status]
    local assignee_name = Task.assignee and Task.assignee.name or nil
    gui.update(row, {
      {
        { elem_mods = { caption = Task.title } },
        { elem_mods = { caption = assignee_name, visible = assignee_name and true or false } },
        {
          elem_mods = {
            sprite = "flib_indicator_" .. status_info.color,
            tooltip = status_info.label,
          },
        },
      },
      {
        { elem_mods = { caption = Task.description, visible = #Task.description > 0 } },
      },
    })
  end
end

--- @param Task Task
function TaskGui:delete_task(Task, completed)
  if completed == nil then
    completed = Task.completed
  end
  local flow = self:get_parent_flow(Task)
  --- @type LuaGuiElement
  local flow = completed and flow.completed or flow.incompleted

  local row = flow[tostring(Task.id)]
  if row then
    row.destroy()
  end

  if #flow.children > 0 and (not completed or self.state.show_completed) then
    flow.visible = true
  else
    flow.visible = false
  end
end

--- @param Task Task
--- @param delta number
function TaskGui:move_task(Task, delta)
  local flow = self:get_parent_flow(Task)
  --- @type LuaGuiElement
  local flow = Task.completed and flow.completed or flow.incompleted
  local row = flow[tostring(Task.id)]
  if row then
    flow.swap_children(row.get_index_in_parent(), row.get_index_in_parent() + delta)
  end
end

function TaskGui:update_show_completed()
  util.recursive_show_completed(self.refs.subtasks_scroll_pane, self.state.show_completed)
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
        actions = { on_click = { gui = { name = "task", id = Task.id }, action = "recenter" } },
        { type = "label", style = "frame_title", caption = { "gui.tlst-task" }, ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
        templates.frame_action_button(
          "utility/close",
          { "gui.close" },
          { gui = { name = "task", id = Task.id }, action = "close" }
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
            actions = {
              on_click = { gui = { name = "task", id = Task.id }, action = "edit_task", task_id = Task.id },
            },
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
              {
                type = "checkbox",
                caption = { "gui.tlst-show-completed" },
                state = false,
                actions = {
                  on_click = { gui = { name = "task", id = Task.id }, action = "toggle_show_completed" },
                },
              },
              { type = "empty-widget", style = "flib_horizontal_pusher" },
              {
                type = "sprite-button",
                style = "flib_tool_button_light_green",
                sprite = "utility/add",
                tooltip = { "gui.tlst-new-task" },
                actions = {
                  on_click = { gui = { name = "task", id = Task.id }, action = "edit_task", parent_task_id = Task.id },
                },
              },
            },
            {
              type = "scroll-pane",
              style = "flib_naked_scroll_pane",
              ref = { "subtasks_scroll_pane" },
              { type = "flow", name = "incompleted", direction = "vertical" },
              { type = "flow", name = "completed", direction = "vertical", visible = false },
            },
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

  -- Add existing tasks
  for _, tasks in pairs({
    Task.completed_tasks,
    Task.tasks,
  }) do
    for _, task_id in pairs(tasks) do
      local Task = global.tasks[task_id]
      if Task then
        self:add_task(Task)
      end
    end
  end
end

--- @param Gui TasksGui
function index.load(Gui)
  setmetatable(Gui, { __index = TaskGui })
end

return index
