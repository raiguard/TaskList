local gui = require("__flib__.gui")

local actions = require("actions")

-- GUI

--- @class NewTaskGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field footer_drag_handle LuaGuiElement
--- @field title_textfield LuaGuiElement
--- @field description_textfield LuaGuiElement
--- @field private_checkbox LuaGuiElement

--- @class NewTaskGui
local NewTaskGui = {}

NewTaskGui.actions = actions

function NewTaskGui:destroy()
  local window = self.refs.window
  if window and window.valid then
    self.refs.window.destroy()
  end
  self.player_table.guis.new_task = nil

  if not self.Parent.state.pinned then
    self.player.opened = self.Parent.refs.window
  end
end

function NewTaskGui:dispatch(msg, e)
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
--- @param Parent TasksGui
function index.new(player, player_table, Parent)
  --- @type NewTaskGuiRefs
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      ref = { "window" },
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
        { type = "label", style = "frame_title", caption = { "gui.tlst-new-task" }, ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_dialog_titlebar_drag_handle", ignored_by_interaction = true },
      },
      {
        type = "frame",
        style = "inside_shallow_frame",
        direction = "vertical",
        { type = "textfield", ref = { "title_textfield" } },
        { type = "textfield", ref = { "description_textfield" } },
        {
          type = "checkbox",
          caption = { "gui.tlst-private" },
          state = false,
          ref = { "private_checkbox" },
        },
      },
      {
        type = "flow",
        style = "dialog_buttons_horizontal_flow",
        {
          type = "button",
          style = "back_button",
          caption = { "gui.cancel" },
          actions = {
            on_click = { gui = "new_task", action = "close" },
          },
        },
        { type = "empty-widget", style = "flib_dialog_footer_drag_handle", ref = { "footer_drag_handle" } },
        {
          type = "button",
          style = "confirm_button",
          caption = { "gui.confirm" },
          actions = {
            on_click = { gui = "new_task", action = "confirm" },
          },
        },
      },
    },
  })

  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window
  refs.footer_drag_handle.drag_target = refs.window

  -- FIXME: This isn't actually working - opened is remaining as the tasks window
  if not Parent.state.pinned then
    player.opened = refs.window
  end

  --- @type NewTaskGui
  local self = {
    Parent = Parent,
    player = player,
    player_table = player_table,
    refs = refs,
  }

  setmetatable(self, { __index = NewTaskGui })

  player_table.guis.new_task = self
end

--- @param Gui NewTaskGui
function index.load(Gui)
  setmetatable(Gui, { __index = NewTaskGui })
end

return index
