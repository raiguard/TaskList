local gui = require("__flib__/gui")

local constants = require("__TaskList__/constants")

local util = require("__TaskList__/scripts/util")

local active_task_button = require("__TaskList__/scripts/gui/active-task-button")

local actions = require("__TaskList__/scripts/gui/tasks/actions")
local templates = require("__TaskList__/scripts/gui/tasks/templates")

-- GUI

--- @class TasksGuiState
--- @field ignore_close boolean
--- @field pinned boolean
--- @field show_completed boolean
--- @field visible boolean

--- @class TasksGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field pin_button LuaGuiElement
--- @field visibility_switch LuaGuiElement
--- @field new_task_button LuaGuiElement
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
    elseif transform == "handle_expand_click" then
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
function TasksGui:get_parent_flow(Task)
  local route = {}

  local owner = Task.owner
  while owner.object_name == "Task" do
    table.insert(route, 1, owner)
    owner = owner.owner
  end

  -- At this point, the owner will be a LuaForce or LuaPlayer
  local flow = owner.object_name == "LuaForce" and self.refs.force_flow or self.refs.private_flow
  for _, owner in pairs(route) do
    local subflow = owner.completed and flow.completed or flow.incompleted --[[@as LuaGuiElement]]
    local row = subflow[tostring(owner.id)]
    if row then
      flow = row.details_flow.subtasks_flow
    end
  end

  return flow
end

--- @param Task Task
--- @param index number?
--- @param completed boolean?
function TasksGui:add_task(Task, index, completed)
  if completed == nil then
    completed = Task.completed
  end
  local flow = self:get_parent_flow(Task)
  local flow = completed and flow.completed or flow.incompleted --[[@as LuaGuiElement]]

  -- Somehow the task state is getting desynced from the GUI sometimes
  local existing = flow[tostring(Task.id)]
  if existing then
    existing.destroy()
  end

  gui.add(flow, templates.task_item(Task, index, completed))

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

  active_task_button.update(self.player, self.player_table)
end

--- @param Task Task
function TasksGui:update_task(Task)
  local flow = self:get_parent_flow(Task)
  local flow = Task.completed and flow.completed or flow.incompleted --[[@as LuaGuiElement]]

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

    active_task_button.update(self.player, self.player_table)
  end
end

--- @param Task Task
function TasksGui:delete_task(Task, completed)
  if completed == nil then
    completed = Task.completed
  end
  local flow = self:get_parent_flow(Task)
  --- @type LuaGuiElement
  local flow = completed and flow.completed or flow.incompleted --[[@as LuaGuiElement]]

  local row = flow[tostring(Task.id)]
  if row then
    row.destroy()
  end

  if #flow.children > 0 and (not completed or self.state.show_completed) then
    flow.visible = true
  else
    flow.visible = false
  end

  active_task_button.update(self.player, self.player_table)
end

--- @param Task Task
--- @param delta number
function TasksGui:move_task(Task, delta)
  local flow = self:get_parent_flow(Task)
  --- @type LuaGuiElement
  local flow = Task.completed and flow.completed or flow.incompleted --[[@as LuaGuiElement]]
  local row = flow[tostring(Task.id)]
  if row then
    flow.swap_children(row.get_index_in_parent(), row.get_index_in_parent() + delta --[[@as uint]])
  end

  active_task_button.update(self.player, self.player_table)
end

function TasksGui:update_show_completed()
  local show_completed = self.state.show_completed

  util.recursive_show_completed(self.refs.force_flow, show_completed)
  util.recursive_show_completed(self.refs.private_flow, show_completed)
end

-- BOOTSTRAP

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function index.new(player, player_table)
  local new_task_on_confirm = player.mod_settings["tlst-new-task-on-confirm"].value
  --- @type TasksGuiRefs
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      name = "tlst_tasks_window",
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
        templates.frame_action_button("utility/close", { "gui.close" }, {
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
            actions = {
              on_checked_state_changed = { gui = "tasks", action = "toggle_show_completed" },
            },
          },
          { type = "empty-widget", style = "flib_horizontal_pusher" },
          {
            type = "switch",
            left_label_caption = { "gui.tlst-force" },
            left_label_tooltip = { "gui.tlst-force-switch-description" },
            right_label_caption = { "gui.tlst-private" },
            right_label_tooltip = { "gui.tlst-private-switch-description" },
            switch_state = "left",
            ref = { "visibility_switch" },
            actions = {
              on_switch_state_changed = { gui = "tasks", action = "toggle_tasks_mode" },
            },
          },
          { type = "empty-widget", style_mods = { width = 20 } },
          {
            type = "sprite-button",
            style = "flib_tool_button_light_green",
            sprite = "utility/add",
            tooltip = new_task_on_confirm and { "gui.tlst-new-task-instruction" } or { "gui.tlst-new-task" },
            ref = { "new_task_button" },
            actions = {
              on_click = { gui = "tasks", action = "edit_task" },
            },
          },
        },
        {
          type = "scroll-pane",
          style = "tlst_tasks_scroll_pane",
          ref = { "scroll_pane" },
          templates.checkboxes_flow("force"),
          templates.checkboxes_flow("private", false),
        },
      },
    },
  })

  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window

  --- @class TasksGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    --- @type TasksGuiState
    state = {
      ignore_close = false,
      pinned = false,
      show_completed = false,
      visible = false,
    },
  }

  setmetatable(self, { __index = TasksGui })

  player_table.guis.tasks = self

  -- Add existing tasks
  local force_table = global.forces[util.get_force(player).index]
  for _, tasks in pairs({
    force_table.completed_tasks,
    force_table.tasks,
    player_table.completed_tasks,
    player_table.tasks,
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
  setmetatable(Gui, { __index = TasksGui })
end

return index
