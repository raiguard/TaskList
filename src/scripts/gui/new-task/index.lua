local gui = require("__flib__.gui")
local table = require("__flib__.table")

local actions = require("actions")

-- GUI

--- @class NewTaskGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field title_textfield LuaGuiElement
--- @field description_textfield LuaGuiElement
--- @field add_to_top_checkbox LuaGuiElement
--- @field private_checkbox LuaGuiElement
--- @field assignee_dropdown LuaGuiElement
--- @field footer_drag_handle LuaGuiElement

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

-- BOOTSTRAP

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param Parent TasksGui
function index.new(player, player_table, Parent)
  local players = { { "gui.tlst-unassigned" } }
  local force = player.force
  local player_selection_index = 0

  for player_index, other_player in pairs(game.players) do
    if other_player.force == force then
      table.insert(players, other_player.name)
      if player_index == player.index then
        player_selection_index = #players
      end
    end
  end

  --- @type NewTaskGuiRefs
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      ref = { "window" },
      actions = {
        on_closed = { gui = "new_task", action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar_flow" },
        actions = {
          on_click = { gui = "new_task", transform = "handle_titlebar_click" },
        },
        { type = "label", style = "frame_title", caption = { "gui.tlst-new-task" }, ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_dialog_titlebar_drag_handle", ignored_by_interaction = true },
      },
      {
        type = "frame",
        style = "tlst_inside_shallow_frame_with_spacing",
        direction = "vertical",
        { type = "label", caption = { "gui.tlst-name" } },
        {
          type = "textfield",
          style = "flib_widthless_textfield",
          style_mods = { horizontally_stretchable = true },
          ref = { "title_textfield" },
        },
        { type = "label", caption = { "gui.tlst-description" } },
        {
          type = "text-box",
          style_mods = { height = 150, width = 300 },
          ref = { "description_textfield" },
        },
        {
          type = "flow",
          { type = "checkbox", caption = { "gui.tlst-add-to-top" }, state = false, ref = { "add_to_top_checkbox" } },
          { type = "empty-widget", style = "flib_horizontal_pusher" },
          {
            type = "checkbox",
            caption = { "gui.tlst-private" },
            state = false,
            ref = { "private_checkbox" },
            actions = {
              on_checked_state_changed = { gui = "new_task", action = "update_assignee_dropdown" },
            },
          },
        },
        {
          type = "flow",
          style_mods = { vertical_align = "center" },
          { type = "label", caption = { "gui.tlst-assignee" } },
          { type = "empty-widget", style = "flib_horizontal_pusher" },
          {
            type = "drop-down",
            items = players,
            selected_index = 1,
            ref = { "assignee_dropdown" },
          },
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
        {
          type = "empty-widget",
          style = "flib_dialog_footer_drag_handle",
          ref = { "footer_drag_handle" },
          actions = { on_click = { gui = "new_task", transform = "handle_titlebar_click" } },
        },
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

  if not Parent.state.pinned then
    player.opened = refs.window
  end

  --- @type NewTaskGui
  local self = {
    Parent = Parent,
    player = player,
    player_table = player_table,
    refs = refs,
    state = {
      player_selection_index = player_selection_index,
    },
  }

  setmetatable(self, { __index = NewTaskGui })

  player_table.guis.new_task = self
end

--- @param Gui NewTaskGui
function index.load(Gui)
  setmetatable(Gui, { __index = NewTaskGui })
end

return index
