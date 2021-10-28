local gui = require("__flib__.gui")

local actions = require("actions")
local templates = require("templates")

-- GUI

--- @class MainGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field pin_button LuaGuiElement
--- @field title_textfield LuaGuiElement
--- @field description_textfield LuaGuiElement
--- @field scroll_pane LuaGuiElement

--- @class MainGui
local MainGui = {}

MainGui.actions = actions

function MainGui:destroy()
  local window = self.refs.window
  if window and window.valid() then
    self.refs.window.destroy()
  end
end

function MainGui:open()
  self.refs.window.bring_to_front()
  self.refs.window.visible = true
  self.state.visible = true

  if not self.state.pinned then
    self.player.opened = self.refs.window
  end

  -- self.player.set_shortcut_toggled("tlst-toggle-gui", true)
end

function MainGui:close()
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

function MainGui:toggle()
  if self.state.visible then
    self:close()
  else
    self:open()
  end
end

function MainGui:dispatch(msg, e)
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

function MainGui:update_tasks()
  -- TEMPORARY: Destroy and recreate it all

  local scroll_pane = self.refs.scroll_pane
  scroll_pane.clear()

  -- TODO: We will have to preserve the ordering of tasks per-player
  for _, task in pairs(global.tasks) do
    scroll_pane.add({ type = "checkbox", caption = task.title, state = task.completed })
  end
end

-- BOOTSTRAP

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function index.new(player, player_table)
  --- @type MainGuiRefs
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      ref = { "window" },
      visible = false,
      actions = {
        on_closed = { gui = "main", action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar_flow" },
        actions = {
          on_click = { gui = "main", transform = "handle_titlebar_click" },
        },
        { type = "label", style = "frame_title", caption = { "gui.tlst-tasks" }, ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
        templates.frame_action_button(
          "flib_pin",
          { "gui.flib-keep-open" },
          { gui = "main", action = "pin" },
          { "pin_button" }
        ),
        templates.frame_action_button("utility/close", { "gui.close-instruction" }, { gui = "main", action = "close" }),
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
              on_click = { gui = "main", action = "create_task" },
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

  --- @type MainGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    --- @class MainGuiState
    state = {
      pinned = false,
      pinning = false,
      visible = false,
    },
  }

  setmetatable(self, { __index = MainGui })

  player_table.guis.main = self
end

--- @param Gui MainGui
function index.load(Gui)
  setmetatable(Gui, { __index = MainGui })
end

--- Safely retrieves the GUI reference, checking for validity of the window.
--- @param player_index number
--- @return MainGui
function index.get(player_index)
  local player_table = global.players[player_index]
  if player_table then
    local Gui = player_table.guis.main
    if Gui and Gui.refs.window.valid() then
      return Gui
    end
  end
end

return index
