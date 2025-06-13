local gui = require("gui")
local table = require("__flib__.table")

local constants = require("constants")
local util = require("scripts.util")

local actions = require("scripts.gui.edit-task.actions")

-- GUI

--- @class EditTaskGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field title_textfield LuaGuiElement
--- @field description_textfield LuaGuiElement
--- @field add_to_top_checkbox LuaGuiElement
--- @field private_checkbox LuaGuiElement
--- @field assignee_dropdown LuaGuiElement
--- @field status_dropdown LuaGuiElement
--- @field footer_flow LuaGuiElement

--- @class EditTaskGui
local EditTaskGui = {}

EditTaskGui.actions = actions

function EditTaskGui:destroy()
  local window = self.refs.window
  if window and window.valid then
    self.refs.window.destroy()
  end
  self.player_table.guis.edit_task = nil

  if self.parent and self.parent.refs.window.valid and not self.parent.state.pinned then
    self.player.opened = self.parent.refs.window --- @diagnostic disable-line
  end

  if self.state.standalone then
    self.player.set_shortcut_toggled("tlst-new-task", false)
  end
end

function EditTaskGui:dispatch(msg, e)
  local transform = msg.transform
  if transform then
    if transform == "handle_titlebar_click" and e.button == defines.mouse_button_type.middle then
      msg.action = "recenter"
    end
  end

  if msg.action then
    local handler = self.actions[msg.action]
    if handler then
      handler(self, msg or {}, e or {})
    end
  end
end

-- BOOTSTRAP

local index = {}

--- @class NewTaskOptions
--- @field parent_gui TasksGui?
--- @field task Task?
--- @field parent_task Task?
--- @field set_private boolean?
--- @field standalone boolean?
--- @field ignore_close boolean?

--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param options NewTaskOptions
function index.new(player, player_table, options)
  options = options or {}
  local Task = options.task
  local Parent = options.parent_gui
  local ParentTask = options.parent_task

  local players = { { "gui.tlst-unassigned" } }
  local priorities = {}
  local force = util.get_force(player)
  local assignee_selection_index = 1
  local priority_selection_index = 5
  local player_selection_index = 0

  local title_caption
  if Task then
    title_caption = { "gui.tlst-edit-task" }
  else
    title_caption = { "gui.tlst-new-task" }
  end

  Task = Task or {}

  local assignable = true
  local owner = Task.owner or ParentTask or {}
  local assignee_index = 0
  while owner.object_name == "Task" do
    owner = owner.owner
  end
  if owner.object_name == "LuaPlayer" then
    assignable = false
    assignee_index = ParentTask and ParentTask.assignee and ParentTask.assignee.index or 0
  else
    assignee_index = Task.assignee and Task.assignee.index or 0
  end

  for player_index, other_player in pairs(game.players) do
    if util.get_force(other_player) == force then
      table.insert(players, other_player.name)
      if player_index == player.index then
        player_selection_index = #players
      end
      if assignee_index == player_index then
        assignee_selection_index = #players
      end
    end
  end

  for i = 1, 10, 1 do
    table.insert(priorities, i)
  end

  priority_selection_index = Task.priority or 5

  local default_task = player.mod_settings["tlst-new-tasks-in-progress"].value and "in_progress" or "not_started"
  local status_items = {}
  local selected_status_index = constants.task_status[default_task].index
  for status_name, status_info in pairs(constants.task_status) do
    if status_name == Task.status then
      selected_status_index = status_info.index
    end
    table.insert(status_items, { "", "[img=flib_indicator_" .. status_info.color .. "]  ", status_info.label })
  end

  --- @type EditTaskGuiRefs
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      name = "tlst_edit_task_window",
      style_mods = { width = 448 },
      direction = "vertical",
      ref = { "window" },
      actions = {
        on_closed = { gui = "edit_task", action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar_flow" },
        actions = {
          on_click = { gui = "edit_task", transform = "handle_titlebar_click" },
        },
        { type = "label",        style = "frame_title",                      caption = title_caption,      ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_dialog_titlebar_drag_handle", ignored_by_interaction = true },
      },
      {
        type = "frame",
        style = "inside_shallow_frame",
        direction = "vertical",
        {
          type = "frame",
          style = "subheader_frame",
          style_mods = { horizontally_stretchable = true },
          visible = ParentTask and true or false,
          {
            type = "label",
            style = "bold_label",
            style_mods = { left_margin = 8 },
            caption = ParentTask and { "gui.tlst-subtask-of", ParentTask.title } or nil,
          },
        },
        {
          type = "flow",
          style_mods = { padding = 12, vertical_spacing = 8 },
          direction = "vertical",
          { type = "label", caption = { "gui.tlst-title" } },
          {
            type = "textfield",
            style = "flib_widthless_textfield",
            style_mods = { horizontally_stretchable = true },
            text = Task.title,
            ref = { "title_textfield" },
            actions = {
              on_confirmed = { gui = "edit_task", action = "confirm" },
            },
          },
          { type = "label", caption = { "gui.tlst-description" } },
          {
            type = "text-box",
            style_mods = { height = 200, width = 400 },
            text = Task.description,
            elem_mods = { word_wrap = true },
            ref = { "description_textfield" },
            actions = {
              on_confirmed = { gui = "edit_task", action = "confirm" },
            },
          },
          {
            type = "flow",
            visible = not Task.title,
            {
              type = "checkbox",
              caption = { "gui.tlst-add-to-top" },
              state = player.mod_settings["tlst-new-tasks-at-top"].value,
              ref = { "add_to_top_checkbox" },
            },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            {
              type = "checkbox",
              caption = { "", { "gui.tlst-private" }, " [img=info]" },
              tooltip = { "gui.tlst-private-description" },
              state = owner and owner.object_name == "LuaPlayer" or false,
              enabled = not ParentTask,
              ref = { "private_checkbox" },
              actions = {
                on_checked_state_changed = { gui = "edit_task", action = "update_assignee_dropdown" },
              },
            },
          },
          {
            type = "flow",
            style_mods = { vertical_align = "center" },
            { type = "label",        caption = { "gui.tlst-assignee" } },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            {
              type = "drop-down",
              items = players,
              selected_index = assignee_selection_index,
              enabled = assignable,
              ref = { "assignee_dropdown" },
            },
          },
          {
            type = "flow",
            style_mods = { vertical_align = "center" },
            { type = "label",        caption = { "gui.tlst-priority" } },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            {
              type = "drop-down",
              items = priorities,
              selected_index = priority_selection_index,
              ref = { "priority_dropdown" },
            },
          },
          {
            type = "flow",
            style_mods = { vertical_align = "center" },
            {
              type = "label",
              caption = { "", { "gui.tlst-area" }, " [img=info]" },
              tooltip = { "gui.tlst-area-description" },
            },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            {
              type = "text-box",
              text = Task.area,
              elem_mods = { word_wrap = true },
              ref = { "area_textfield" },
              actions = {
                on_confirmed = { gui = "edit_task", action = "confirm" },
              },
            },
          },
          {
            type = "flow",
            style_mods = { vertical_align = "center" },
            {
              type = "label",
              caption = { "", { "gui.tlst-status" }, " [img=info]" },
              tooltip = { "gui.tlst-status-description" },
            },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            {
              type = "drop-down",
              items = status_items,
              selected_index = selected_status_index,
              ref = { "status_dropdown" },
            },
          },
        },
      },
      {
        type = "flow",
        style = "dialog_buttons_horizontal_flow",
        actions = { on_click = { gui = "edit_task", transform = "handle_titlebar_click" } },
        ref = { "footer_flow" },
        {
          type = "button",
          style = "back_button",
          caption = { "gui.cancel" },
          actions = {
            on_click = { gui = "edit_task", action = "close" },
          },
        },
        { type = "empty-widget", style = "flib_dialog_footer_drag_handle", ignored_by_interaction = true },
        Task.title and {
          type = "button",
          style = "tlst_red_dialog_button",
          caption = { "gui.delete" },
          actions = {
            on_click = { gui = "edit_task", action = "delete" },
          },
        } or {},
        Task.title and {
          type = "empty-widget",
          style = "flib_dialog_footer_drag_handle",
          ignored_by_interaction = true,
        } or {},
        {
          type = "button",
          style = "confirm_button",
          caption = { "gui.confirm" },
          actions = {
            on_click = { gui = "edit_task", action = "confirm" },
          },
        },
      },
    },
  })

  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window
  refs.footer_flow.drag_target = refs.window

  if Parent and not Parent.state.pinned then
    Parent.state.ignore_close = true
    player.opened = refs.window
  elseif options.standalone then
    player.opened = refs.window
    player.set_shortcut_toggled("tlst-new-task", true)
  end

  --- @class EditTaskGui
  local self = {
    parent = Parent,
    player = player,
    player_table = player_table,
    refs = refs,
    state = {
      just_confirmed = options.ignore_close and true or false,
      parent_task = ParentTask,
      player_selection_index = player_selection_index,
      standalone = options.standalone,
      --- @type Task|nil
      task = Task.title and Task or nil,
    },
  }

  setmetatable(self, { __index = EditTaskGui })

  player_table.guis.edit_task = self

  if options.set_private then
    self.refs.private_checkbox.state = true
    self.actions.update_assignee_dropdown(self)
  end

  self.refs.title_textfield.select_all()
  self.refs.title_textfield.focus()
end

--- @param Gui EditTaskGui
function index.load(Gui)
  setmetatable(Gui, { __index = EditTaskGui })
end

return index
